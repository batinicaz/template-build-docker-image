# template-build-docker-image

Template repo for building docker images and pushing to GHCR.

Images are built automatically every day at 2AM on the main branch and scanned using [Grype](https://github.com/anchore/grype).

## Usage

Once a new repo is created from this template, you should:

1. Update the [Dockerfile](./Dockerfile) to match your needs. Recommend building the final image from one of [chainguard's](https://edu.chainguard.dev/chainguard/chainguard-images/reference/) images.
2. Update the workflow files in [.github/workflows](./.github/workflows):
   1. Update the `resolve-versions` step with the dependencies your image needs.
   2. Replace the `smoke_test` with appropriate tests for your image.
   3. Add `no_cache_filter` for any Dockerfile stages that install packages (e.g. `apt-get update`, `apk upgrade`) to ensure fresh packages on scheduled builds.
3. Update [.grype.yaml](./.grype.yaml) with ignore rules for any downloaded binaries that you always pull the latest version of (and therefore just wait for upstream patches).
4. Update this README. Here is an example:

```markdown
# <imageName>

Builds an image containing:

* <tools>

Built every day at 2AM to get latest changes and scanned for vulnerabilities using [Grype](https://github.com/anchore/grype).

## Usage

You can use the image in GitHub actions with a job definition like the one below:

```yaml
  job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Run image
        uses: docker://ghcr.io/batinicaz/<imageName>:<imageTag>
```
