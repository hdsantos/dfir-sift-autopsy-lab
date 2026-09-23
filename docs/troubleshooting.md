# Troubleshooting

This page collects the most common problems observed with the course-tested SIFT + Autopsy environment.

| Symptom | Probable cause | Suggested action |
|---|---|---|
| `Insecure directory in $ENV{PATH}` | Autopsy 2.x legacy version is being used | Use Autopsy 4.x as described in the installation guide. |
| `dependency problems... libewf2 is not installed` | Conflict between the `gift` PPA libraries and Ubuntu package names | Follow the library-resolution procedure in the installation guide. |
| `UnsupportedClassVersionError` when starting Autopsy | Incompatible Java/Autopsy combination | Use the course-tested Autopsy/Java combination documented in the installation guide. |
| `apt install autopsy` installs the old version | Ubuntu repository provides the legacy package | Install Autopsy 4.x manually as described in the guide. |
| Autopsy cannot write logs or create/use cases correctly | Installation/case directory ownership is wrong | Check ownership; for the documented installation run `sudo chown -R $USER:$USER ~/autopsy`. |
| `Fatal Error! Problem with Sleuth Kit JNI` or missing `libtsk.so.23` | `sleuthkit-java` was removed or the runtime library is unavailable | Reinstall the course-tested `sleuthkit-java`, run `sudo ldconfig`, and reapply the package hold. |
| Autopsy window does not close cleanly | Known Linux/NetBeans background-thread behaviour | Close the case first; if necessary terminate the Autopsy process from the terminal. |
| Empty file tree after adding a valid data source | Embedded Solr failed during ingest | Correct Autopsy directory ownership, remove the data source, and add it again so ingest runs from the beginning. |
| `sleuthkit : Depends: libtsk19 ...` | Installing the CLI package through `apt` conflicts with the selected libraries | Do not install that package via `apt`; use the source-build procedure or `pytsk3` described in the installation guide. |

## Before asking for help

Please record:

```bash
lsb_release -a
java -version
dpkg -l | grep sleuthkit-java
apt policy libewf libvhdi libvmdk
```

Also include the exact command that failed and the complete error message.

For installation details and recovery commands, return to the **[Installation Guide](installation.md)**.
