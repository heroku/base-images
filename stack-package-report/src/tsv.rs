//! Parsing of TSV input.

use std::collections::BTreeMap;
use std::io::{self, BufRead, BufReader, Read};

pub(crate) fn parse<T, E>(
    input: impl Read,
    column_mapper: impl Fn(Vec<String>) -> Result<T, E>,
) -> Result<Vec<T>, TsvParseError<E>>
where
    E: std::error::Error,
{
    BufReader::new(input)
        .lines()
        .map(|line| {
            line.map_err(TsvParseError::IoError)
                .map(|line| line.split('\t').map(String::from).collect::<Vec<_>>())
                .and_then(|line| column_mapper(line).map_err(TsvParseError::ColumnMapperError))
        })
        .collect()
}

#[derive(Debug, thiserror::Error)]
pub(crate) enum TsvParseError<E> {
    #[error("I/O error: {0}")]
    IoError(#[from] io::Error),
    #[error(transparent)]
    ColumnMapperError(E),
}

pub(crate) fn key_value_map_column_mapper(
    columns: Vec<String>,
) -> Result<(String, String), UnexpectedColumnCountError> {
    <[String; 2]>::try_from(columns)
        .map(|[key, value]| (key, value))
        .map_err(UnexpectedColumnCountError)
}

#[derive(Debug, thiserror::Error)]
#[error("unexpected amount of columns in: {0:?}")]
pub(crate) struct UnexpectedColumnCountError(Vec<String>);

pub(crate) fn parse_key_value_map(
    input: impl Read,
) -> Result<BTreeMap<String, String>, TsvParseError<UnexpectedColumnCountError>> {
    parse(input, key_value_map_column_mapper).map(|rows| rows.into_iter().collect())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_returns_empty_vec_for_empty_input() {
        let parsed: Vec<Vec<String>> =
            parse(&b""[..], Ok::<_, UnexpectedColumnCountError>).unwrap();
        assert_eq!(parsed, Vec::<Vec<String>>::new());
    }

    #[test]
    fn parse_splits_each_line_into_tab_separated_columns() {
        let input = "a\tb\tc\nd\te\n".as_bytes();
        let parsed: Vec<Vec<String>> = parse(input, Ok::<_, UnexpectedColumnCountError>).unwrap();
        assert_eq!(
            parsed,
            vec![
                vec![String::from("a"), String::from("b"), String::from("c")],
                vec![String::from("d"), String::from("e")],
            ]
        );
    }

    #[test]
    fn parse_propagates_column_mapper_error() {
        let input = "only-one-column\n".as_bytes();
        let result = parse(input, key_value_map_column_mapper);
        assert!(matches!(
            result,
            Err(TsvParseError::ColumnMapperError(
                UnexpectedColumnCountError(_)
            ))
        ));
    }

    #[test]
    fn key_value_map_column_mapper_accepts_exactly_two_columns() {
        let result = key_value_map_column_mapper(vec![String::from("k"), String::from("v")]);
        assert_eq!(result.unwrap(), (String::from("k"), String::from("v")));
    }

    #[test]
    fn key_value_map_column_mapper_rejects_other_column_counts() {
        for columns in [
            vec![],
            vec![String::from("only")],
            vec![String::from("a"), String::from("b"), String::from("c")],
        ] {
            assert!(key_value_map_column_mapper(columns).is_err());
        }
    }

    #[test]
    fn parse_key_value_map_collects_into_btree_map() {
        let input = "bash\t5.1\nlibfoo\t1.0\n".as_bytes();
        let parsed = parse_key_value_map(input).unwrap();
        assert_eq!(
            parsed,
            [
                (String::from("bash"), String::from("5.1")),
                (String::from("libfoo"), String::from("1.0")),
            ]
            .into_iter()
            .collect()
        );
    }
}
