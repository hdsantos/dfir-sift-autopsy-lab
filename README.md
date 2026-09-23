# DFIR SIFT + Autopsy Lab

Companion repository for the **Digital Forensics Analysis** laboratory environment in the MSc in Cybersecurity.

## Laboratory environment

The reference workstation is based on:

- Ubuntu 22.04 LTS
- SANS SIFT Workstation
- Autopsy 4.x
- The Sleuth Kit
- Volatility 3
- Wireshark and other DFIR tools included in or used alongside SIFT

The environment is intended to support **disk**, **memory**, and **network** forensic analysis throughout the course.

## Installation

The recommended deployment is a virtual machine (VirtualBox, VMware, or equivalent).

See **[Installation Guide](docs/installation.md)**.

Allow approximately **60–90 minutes** for the initial installation (including varification and tests), depending on network and host performance.

### Minimum requirements

- 2 CPU cores
- 4 GB RAM (8 GB recommended where available)
- 40 GB free disk space (100 GB is recommended)
- Stable Internet connection during installation - be carefull with **bridge** network adapters when using eduroam

## Validate the environment

## Validate the environment

After completing the installation, verify that your DFIR Lab environment is correctly configured before starting the laboratory exercises.

The validation procedure checks the main software components and confirms that Autopsy can create and process a forensic case successfully.

➡️ Follow the [Environment Validation Guide](docs/validation.md).


The final validation should confirm that you can:

- start Autopsy 4.x;
- create a new case;
- add a forensic disk image;
- browse the filesystem;
- run ingest without Solr errors.

## Troubleshooting

Common installation and runtime problems are collected in **[Troubleshooting](docs/troubleshooting.md)**.

## Exercises

Course exercises will be added progressively under [`exercises/`](exercises/).

## Version policy

This repository documents a **course-tested configuration**, not necessarily the newest available release of every component. Changes to validated versions should be tested before being adopted by students. See [CHANGELOG.md](CHANGELOG.md).

## Licence

The original teaching material and repository-specific scripts are released under the [MIT License](LICENSE), unless a file explicitly states otherwise.

Third-party software, datasets, documentation, trademarks, and linked resources remain subject to their respective licences and terms. The MIT License in this repository does **not** relicense SIFT Workstation, Autopsy, The Sleuth Kit, Volatility, Wireshark, Ubuntu, or any third-party dataset.
