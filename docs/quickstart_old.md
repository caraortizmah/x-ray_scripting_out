# Quick Start Guide

Run the X-ray Spectroscopy Pipeline in 2 minutes.

## Prerequisites

- Linux or macOS
- Standard Unix tools (awk, grep, sed, etc.)

## Step 1: Clone Repository

Clone the `x-ray_scripting_out` repository using Git

```bash
git clone https://github.com/caraortizmah/x-ray_scripting_out.git
cd x-ray_scripting_out
```

## Step 2: Set up the pipeline

Move the scripts outside the `scr` folder

```bash
mv scr/*.sh .
```

### Step 3: Run

The pipeline can be run in two ways: a simpler, more automated approach using `helper_man.sh`, or a more customizable option with `manager.sh`.  

- **`manager.sh`**: This is the primary script that executes all the pipeline steps in a sequential (noticeable) order, as indicated by their step-specific names.  
- **`helper_man.sh`**: This provides an easier method by reading the required parameters from a separate file, named `config.info`.  

#### Recommended: Automated Method

Run the following command:

```bash
./helper_man.sh
```

`helper_man.sh` uses the information in `config.info` to execute `manager.sh`.

Important: Read further about the format of the `config.info` in [docs/goodtoknow_config.info.md](goodtoknow_config.info.md)

Information about running examples can be found in the [docs/examplesrun.md](examplesrun.md) file.

## Support

- Review the extended documentation in `docs/` for a deeper explanation
- Check examples/ directory for sample configs

---

Enjoy!