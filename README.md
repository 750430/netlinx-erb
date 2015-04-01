# NetLinx ERB

netlinx-erb

A code generation framework for AMX NetLinx control systems.

[![Gem Version](https://badge.fury.io/rb/netlinx-erb.svg)](http://badge.fury.io/rb/netlinx-erb)
[![API Documentation](http://img.shields.io/badge/docs-api-blue.svg)](http://www.rubydoc.info/gems/netlinx-erb)
[![MIT License](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](https://github.com/amclain/netlinx-erb/blob/master/license.txt)

Syntax highlighting is included in [sublime-netlinx](https://github.com/amclain/sublime-netlinx#sublime-text-amx-netlinx-plugin).


## Overview

Use a descriptive syntax...

[![ERB Template](screenshots/example_erb.png)](https://github.com/amclain/netlinx-erb/blob/master/screenshots/example_erb.png)

To generate repetitive NetLinx code...

[![Generated AXI File](screenshots/example_axi.png)](https://github.com/amclain/netlinx-erb/blob/master/screenshots/example_axi.png)

With netlinx-erb, configuration is separated from implementation. For example,
touch panel button numbers and video inputs (configuration) are separated from
the code that handles video patching when a button is pressed (implementation).
Under this paradigm, reconfiguration can happen quickly as project requirements
change. Since the implementation code is separated from these changes and code
generation is automated, there is less chance of inducing bugs into the system
when a change in configuration happens.

For example, in the code above, let's say the client decides to add a camera
to the system. All we have to do to update this file is add the following to
the `video_sources` hash:

```ruby
    BTN_VID_CAMERA: { btn: 14, input: :VID_SRC_CAMERA }
```

This defines a new touch panel button constant `BTN_VID_CAMERA`, assigns that
constant to channel number `14`, and adds a case to the button event handler
to switch the video matrix to `VID_SRC_CAMERA` when the button is pressed.
Since the implementation code for this change is auto-generated, and we know
that the implementation code works correctly, it is unlikely that this change
will create any bugs. There is a clear advantage to this method as the amount
of code grows and the project becomes more complex.

### RPC

A remote procedure call (RPC) mechanism is included to be able to call NetLinx
functions through ICSLan (NetLinx Diagnostics, Telnet, etc.). To issue an RPC
function call, `send_string` to `34500:1:0`. The body of the string should
start with the name of the function, followed by a space-separated list of
arguments.

For the following function:

```c
define_function patch_video(integer input, integer output)
{
    // Patch video matrix.
}
```

`patch_video 1 2` is the RPC string that would patch video input 1 to output 2.

### Backward Compatibility

The NetLinx files generated by netlinx-erb are designed to be fully backward
compatible with traditional NetLinx project development, including readability
and adequate whitespace. This means that any NetLinx programmer can take over
maintenance of the project using the standard development tools provided by AMX
and does not need to have any experience with netlinx-erb.

It is important to note that ***this process is a one-way street***. Once the
generated files are modified by hand, the changes must be manually converted
back to the template files or else they will be erased the next time the
generator is run. Backward compatibility is designed for projects that are
permanently passed to other programmers who are not familiar with netlinx-erb
and are not able to learn it, like due to time constraints.


## Issues, Bugs, Feature Requests

Any bugs and feature requests should be reported on the GitHub issue tracker:

https://github.com/amclain/netlinx-erb/issues


**Pull requests are preferred via GitHub.**

Mercurial users can use [Hg-Git](http://hg-git.github.io/) to interact with
GitHub repositories.


## Installation

netlinx-erb is available as a Ruby gem.

1. Install [Ruby](https://www.ruby-lang.org) 2.1.5 or higher.
    * Windows: Use [RubyInstaller](http://rubyinstaller.org/downloads/)
        and make sure ruby/bin is in your [system path](http://www.computerhope.com/issues/ch000549.htm).
    * Linux: Use [rbenv](https://github.com/sstephenson/rbenv#basic-github-checkout).
    
2. Open the [command line](http://www.addictivetips.com/windows-tips/windows-7-elevated-command-prompt-in-context-menu/)
    and type:

    ***gem install netlinx-erb***


*NOTE: The NetLinx compiler executable provided by AMX, nlrc.exe, must be
installed on your computer for this utility to work. It is included in the
NetLinx Studio installation by default.*

**If you receive the following error when running gem install:**
```text
Unable to download data from https://rubygems.org/ - SSL_connect returned=1
```

Follow this guide:
[Workaround RubyGems' SSL errors on Ruby for Windows (RubyInstaller)](https://gist.github.com/luislavena/f064211759ee0f806c88)


## Prerequisites

netlinx-erb is a complex utility and does have a learning curve. However, the
time invested in learning this utility pays off in time saved from generating
code that would otherwise be handwritten, and troubleshooting fewer bugs. Due
to this, project maintenance also becomes easier.

### Programming Languages

Basic experience with the [Ruby programming language](https://www.ruby-lang.org)
is required, as well as [ERB templating](http://www.stuartellis.eu/articles/erb/).

**Resources:**

* [Head First Ruby](http://shop.oreilly.com/product/9780596803995.do)
* [Design Patterns in Ruby](http://www.amazon.com/Design-Patterns-Ruby-Russ-Olsen/dp/0321490452/ref=sr_1_1?ie=UTF8&qid=1424904889&sr=8-1&keywords=ruby+design+patterns)
* [Practical Object-Oriented Design in Ruby](http://www.amazon.com/Practical-Object-Oriented-Design-Ruby-Addison-Wesley/dp/0321721330/ref=sr_1_2?ie=UTF8&qid=1424904889&sr=8-2&keywords=ruby+design+patterns)

### Development Tools

#### Text Editor

A good text editor is crucial for working with netlinx-erb. [Sublime Text 3](http://www.sublimetext.com/3)
with the [sublime-netlinx](https://github.com/amclain/sublime-netlinx#sublime-text-amx-netlinx-plugin)
plugin is recommended, as it provides syntax highlighting and code completion
for netlinx-erb.

>***Use a Single Editor Well***
>
>*The editor should be an extension of your hand; make sure your editor is
>configurable, extensible, and programmable.*
>-- [The Pragmatic Programmer](http://www.informit.com/store/pragmatic-programmer-from-journeyman-to-master-9780201616224)

#### Command Prompt

The command prompt is a powerful, flexible way to issue commands. Due to this,
many of the tools that netlinx-erb is built on use command line interfaces.

SS64 is a great [command line reference](http://ss64.com/).


## Getting Started

## Code Examples
