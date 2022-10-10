Top Level Dupe Info Propagation
===============================

![This script was last tested in Nuix 9.6](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-9.6-green.svg)

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
| **Also Pull in Duplicates of Selected Top Level Items** | This setting only appears when items were selected before running the script.  When checked, duplicates of top level items in your selection will also be processed. The intent of this setting is after you process some data, you select the newly ingested items.  This setting then also includes duplicates of the newly ingested items to also be updated. |
| **Duplicate Custodians Field** | Name of the custom metadata field to which duplicate custodian information will be recorded. |
| **Apply Duplicate Custodians Tags** | When checked a tag will be applied to each item with a name corresponding to the duplicate custodians value. |
| **Propagate Dupe Paths as** | When checked a custom metadata field will be applied to items containing the item paths of the duplicate items. Use the associated text field to specify the field used to record the duplicate paths value to when **Propagate Dupe Paths as** is checked. |
| **Duplicate Path Type** | Determines duplicate paths will be calculated such that they contain the item and ancestor items' names or just the ancestor items' names. |
| **Duplicates Must Also be Top Level** | When checked, an item is only considered duplicate of a top level item if that item is itself also top level.  This prevents a top level item from being considered duplicate to the same email which is an attachment elsewhere. |
| **Duplicates Must Also be in Selection** | *This choice only shows up if items were selected when the script was ran.*  When checked, only items within the selection of items are candidates for being considered being duplicates. |
| **Duplicate Values Type** | Determines whether the duplicate custodians calculation for given item includes its own custodian or just the custodian of the other duplicate items.  Note that even when not including an item's own custodian in the calculation, it still may be in the calculated result if the custodian has other copies of the same item. |

### Duplicate Values Type

To help clarify the **Duplicate Values Type**, lets imagine we have some data with 3 custodians: **Aly**, **Bob** and **Carl**.  Now imagine all 3 have a copy of a file.  If you had selected **Duplicates Custodian Values** then you might see the following duplicate custodians values recorded:

- For the **Aly** copy: **Bob**, **Carl**
- For the **Bob** copy: **Aly**, **Carl**
- For the **Carl** copy: **Aly**, **Bob**

Notice how each is reported from the perspective of the custodian as who the *other* custodians are.  Alternatively, if you were to instead choose **Item and Duplicates Custodian Values** you might instead see:

- For the **Aly** copy: **Aly**, **Bob**, **Carl**
- For the **Bob** copy: **Aly**, **Bob**, **Carl**
- For the **Carl** copy: **Aly**, **Bob**, **Carl**

Notice how now each is reported instead as *all* of the custodian with a copy.

Sometimes this is referred to as **Other Custodians** vs **All Custodians**.  The **All Custodians** (**Item and Duplicates Custodian Values**) approach generally requires fewer calculations by the script and therefore tends to perform better.  If the **Item and Duplicates Custodian Values** setting yields values you can use, I would recommend you use that.

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2022 Nuix

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
