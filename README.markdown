# What is GitX?

GitX is a graphical client for the `git` version control system, written
specifically for OS X Mavericks.

# What is GitX-min?

This fork (variant) of GitX/GitX-dev focuses on minimalism. 

# Development

Developing for GitX-min has a few requirements above and beyond those
for mainline GitX.

Most third-party code is referenced with Git submodules, so [read up](http://book.git-scm.com/5_submodules.html) on those if you're not familiar.

  * Very recent Xcode install, 5.1 release strongly recommended.
  * Most development is done on OS X Mavericks, earlier host platforms may or may not work at all.
  * `Homebrew` and `xctool` for running Objective-Git’s `bootstrap` script.
  * `CMake` with a working command-line compiling environment for building `libgit2`.
  * `node.js` for building `SyntaxHighlighter` (not necessary unless you're updating SyntaxHighlighter itself.)

To get GitX-min to compile locally you need to:

  1. Clone the repository locally: `git clone https://github.com/frodeaa/gitx.git`
  2. After cloning it `cd gitx` and then recursively initialize all submodules: `git submodule update --init --recursive`
  3. Then prepare objective-git by running its bootstrap script: `cd objective-git && ./script/bootstrap`
  4. Then compile objective-git `cd objective-git && ./script/update_libgit2`

After that you should be able to open the Xcode project and build successfully.

# License

GitX is licensed under the GPL version 2. For more information, see the attached COPYING file.

# Usage

GitX itself is fairly simple. Most of its power is in the 'gitx' binary, which
you should install through the menu. the 'gitx' binary supports most of git
rev-list's arguments. For example, you can run `gitx --all` to display all
branches in the repository, or `gitx -- Documentation` to only show commits
relating to the 'Documentation' subdirectory. With `gitx -Shaha`, gitx will
only show commits that contain the word 'haha'. Similarly, with `gitx
v0.2.1..`, you will get a list of all commits since version 0.2.1.

# Helping out

Any help on GitX is welcome. GitX is programmed in Objective-C, but even if
you are not a programmer you can do useful things. A short selection:

  * Give feedback
