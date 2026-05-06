#!/bin/bash

#
# This file contains ghost definitions for aliases, that way they appear in intellisense autocomplete lists.
#

# Hide debug traces of the function this macro is called in, as well as child calls.
# Either use `core::show_trace` or exit the used scope to reverse the effect.
# NOTE: This is ignored when `FORCE_DEBUG` is set.
core::hide_trace() { :; }

# Hide debug traces of the function this macro is called in, as well as child calls.
# Either use `core::show_trace` or exit the used scope to reverse the effect.
# NOTE: Unlike `core::show_trace`, `FORCE_DEBUG` being set will have no effect on this macros behavior.
core::ignore_trace() { :; }

# 
core::show_trace() { :; }
