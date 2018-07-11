Top Level Dupe Info Propagation
===============================

![Last tested in Nuix 7.4](https://img.shields.io/badge/Nuix-7.4-green.svg)

View the GitHub project [here](https://github.com/Nuix/Top-Level-Dupe-Info-Propagation) or download the latest release [here](https://github.com/Nuix/Top-Level-Dupe-Info-Propagation/releases).

# Overview

**Written By:** Jason Wells

Annotates top level items and their descendants with information about duplicate custodians and duplicate paths.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Settings

| Setting | Description |
|---------|-------------|
| **Dupe Custodians Field** | Name of the custom metadata field to which duplicate custodian information will be recorded. |
| **Apply Duplicate Custodians Tags** | When checked a tag will be applied to each item with a name corresponding to the duplicate custodians value. |
| **Propagate Dupe Paths** | When checked a custom metadata field will be applied to items containing the item paths of the duplicate items. |
| **Dupe Paths Field** | The field to record the duplicate paths value to when **Propagate Dupe Paths** is checked. |
| **Dupe Path Type** | Determines duplicate paths will be calculated such that they contain the item and ancestor items' names or just the ancestor items' names. |
| **Dupes Must be Top Level Also** | When checked, an item is only considered duplicate of a top level item if that item is itself also top level.  This prevents a top level item from being considered duplicate to the same email which is an attachment elsewhere. |
| **Dupe Values Type** | Determines whether the duplicate custodians calculation for given item includes its own custodian or just the custodian of the other duplicate items.  Note that even when not including an item's own custodian in the calculation, it still may be in the calculated result if the custodian has other copies of the same item. |
| **Only Duplicates in Selection** | *This choice only shows up if items were selected when the script was ran.*  When checked, only items within the selection of items are candidates for being considered being duplicates. |

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```