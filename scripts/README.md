# Core Scripts

Scripts to support the operation of core infrastructure.

## Preparing the parent project

Given that the core infrastructure is designed to be used [as a Git submodule](../README.md#usage), it is further intended that this scripts folder be symlinked to from within a scripts folder in the top of the active / parent project.

For example:
```bash
cd my-user-service
mkdir scripts
cd scripts
ln -s ../infrastructure/core/scripts core
```

## Use

The scripts should be accessed via that symlink, for example:
```bash
cd my-user-service
scripts/core/ecr_repository/get_login_password.py
```

## Setting up to run the scripts

Scripts in this folder's subfolders require extra Python packages to be installed, and therefore should be run in a Virtualenv.

Because on the one hand the parent project will probably have its own package requirements, and on the other hand it's undesirable to maintain package patching for multiple similar virtualenvs, it is intended that there is a single Virtualenv set up, in the top level project, which provides for the needs of all the scripts. (And, being practical, it's very unlikely that there will be much divergence in needs between scripts anyway).

### Set up Virtualenv
While it's not the job of this README to explain Python operations in general, the following may be a helpful prompt as to how to at least get started with Virtualenv so that the scripts can be run.

This is intended to be run from the top-level project folder.

```bash
cd my-user-service/scripts
virtualenv -p PYTHONVERSION venv
```
where `PYTHONVERSION` is the desired Python version number, e.g. `3.9`, `3.11`  or whatever.

### Activate the Virtualenv

This is required to bring the virtual environment into your shell session and to make available the installed packages.

```bash
source venv/bin/activate
```

### Compile the requirements.txt file

[Pip-Tools](https://pypi.org/project/pip-tools/) is used to compile basic, primary package requirements and identify all downstream dependencies.

The assumption here is that the top-level scripts folder has its own `requirements.in` file whose contents will be merged with the top-level project's `requirements.in` file. **If your scripts folder is newly set up and has no `requirements.in` file** then you're advised to set one up with only a comment inside it to provide clarity for other engineers, for example:

```
# Add only package requirements which are in addition to those
# expressed in core/requirements.in
```
scripts/requirements.in

Note this step is necssary to avoid errors in the step which follows:

```bash
pip install pip-tools
pip-compile --output-file requirements.txt requirements.in core/requirements.in
```

### Install the required packages

```bash
pip install -r requirements.txt
```

You can now run the Python scripts enclosed in the top level project and in this core subfolder, via the `core/` symlink.
