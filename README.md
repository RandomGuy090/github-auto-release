# github-auto-release
I've created a script helping in automatic deployment applications with CI/CD apps (like jenkins)

## usage

```bash
  curl https://raw.githubusercontent.com/RandomGuy090/github-auto-release/main/auto-release.sh > run.sh
  bash run.sh -r {URL} -t {TOKEN}
```
## help
```bash
  auto release on github. Script gets last version and increments it. After it creates new release
    -r  github release url
      e.g. https://api.github.com/repos/{USER}/{REPO}/releases
    -t  github token
    -p  set as prerelease
    -a  autogenerate description for release

```
