# `Run Project` Start Script

When accessing a `Run Project` page (such as http://run.azk.io/start/?repo=run-project/stringer), the `start.sh` script will be displayed to be executed.

Then, `start.sh` will:

* Check if `azk` is installed and, if it's not, install `azk`;
* Run `azk start` command to run the specified GitHub project;

In order to install `azk`, `start.sh` will check if either `wget` or `curl` is installed. If none of them are available, it'll displayed a message pointing to installation instructions on `azk` documentation.
