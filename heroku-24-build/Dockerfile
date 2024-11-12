ARG BASE_IMAGE=heroku/heroku:24
FROM $BASE_IMAGE

# We have to temporarily switch back to root, since the run image sets a non-root default `USER`.
USER root
RUN --mount=target=/build /build/setup.sh

# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#build-image
# The `io.buildpacks.base.*` labels are inherited from the run image, so don't need to be repeated here.
USER heroku
ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000

# Stack IDs are deprecated, but we still set this for backwards compatibility:
# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#iobuildpacksstack-labels
ENV CNB_STACK_ID="heroku-24"

# Match HOME operation done in [heroku-22](https://github.com/usiegj00/base-images/blob/3bed84a6cf88bc6535b1ef18acbc454f88c854d8/heroku-22-cnb/Dockerfile#L17). 
# This is related to [the user HOME issue exposed here](https://github.com/heroku/base-images/pull/332).
ENV HOME=/workspace
