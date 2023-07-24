# Scripts

Scripts to support the operation of core infrastructure.

Consult the executable files for descriptions and explanations of their operation.

For simplicity (of patching) there is a single requirements.txt file which covers all scripts (and should only be compiled with `pip-compile`).

## Setting up to run the scripts

### Set up Virtualenv
While it's not the job of this README to explain Python operations in general, the following may be a helpful prompt as to how to at least get started with Virtualenv so that the scripts can be run.

```bash
cd infrastructure/core/scripts
virtualenv -p PYTHONVERSION venv
```
where `PYTHONVERSION` is the desired Python version number, e.g. `3.9`, `3.11`  or whatever.

### Activate the Virtualenv

This is required to bring the virtual environment into your shell session and to make available the installed packages.

```bash
source venv/bin/activate
```

### Compile the requirements.in file

You only need to do this if you have altered `requirements.in` in any way.

```bash
pip install pip-tools
pip-compile
```

### Install the required packages

```bash
pip install -r requirements.txt
```

You can now run the Python scripts enclosed here in the sub-folders.
