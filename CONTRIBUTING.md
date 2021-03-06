# Contributing Guidelines

We try to be as open and collaborative as possible, but please understand that working on detection scripts is only a fraction of our work responsibilities.


## Reporting an Issue

Please use the GitHub issue tracker to report bugs and improvement requests.
However, after two months of a vulnerability being public we can only commit to fixing important bugs.

Before submitting issue:
* Check for similar, already-filed issues
* Try to reproduce the issue on Red Hat Enterprise Linux if possible
* Check if the latest version of the detection script was used
* Isolate the problem to one system only
* Include full output of the detection script when run with the `--debug` option
* Include details of the OS (including architecture) and version of Bash used

## Pull Requests

We only accept pull requests for vulnerability detection scripts which already exist.
The same two month support window applies, so generally only pull requests to fix important bugs will be accepted after that time period.

Pull request needs to meet these requirements:
* Code must follow [good programming practices for Bash](http://mywiki.wooledge.org/FullBashGuide)
* Code must pass tests using [Bash Automated Testing System](https://github.com/sstephenson/bats) on all supported RHEL versions (done by CI)
* Code must pass [Shellcheck](https://github.com/koalaman/shellcheck) without warnings (done by CI)
* Any `shellcheck disable` directives should be explained on the previous line
* Bug fixes should include a test that fails with the previous version of the script and passes in the fixed version
