# Package

version       = "0.1.0"
author        = "kelp"
description   = "kelps funny package manager - weird mix between portage and guix kindof? "
license       = "Apache-2.0"
srcDir        = "src"
bin           = @["kelpk_g"]


# Dependencies

requires "nim >= 2.2.10"

requires "commandant >= 0.15.0"