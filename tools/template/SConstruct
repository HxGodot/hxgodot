#!/usr/bin/env python
import os, sys, subprocess

from SCons.Tool import msvc, mingw
from SCons.Variables import *

default_platform = "windows"
platforms = ("windows", "linux", "macos")
architecture_array = ["x86_64", "x86_32"]
haxe_target_array = ['cpp', 'cppia']

opts = Variables([], ARGUMENTS)
env = Environment(tools=["default"], PLATFORM="")

opts.Add(EnumVariable('target', "Compilation target", 'debug', ['debug', 'release']))
opts.Add(
    EnumVariable(
        "platform",
        "Target platform",
        default_platform,
        allowed_values=platforms,
        ignorecase=2,
    )
)
opts.Add(EnumVariable("arch", "CPU architecture", architecture_array[0], architecture_array))
opts.Add(BoolVariable("scriptable", "Compile your cpp-code with cppia context extensions", False))
opts.Add(EnumVariable('haxe_target', 'Haxe Target', haxe_target_array[0], haxe_target_array))
opts.Update(env)

# hxgodot haxelib folder
hxgodotPath = subprocess.check_output('haxelib libpath hxgodot', shell=True).decode('utf-8').strip()

libTargetString = '-debug' if env['target'] == 'debug' else ''

# hxgodot libnames
static_lib_name = f'libHxGodot{libTargetString}'
shared_lib_name = f"hxgodot.{env['target']}.{env['arch']}"

# platform specifics
link_flags = []
cc_flags = []
if env['platform'] == "windows":
    static_lib_name += '.lib'
    shared_lib_name = 'lib' + shared_lib_name + '.dll'
    env.Append(ENV = os.environ)

    if env["arch"] == "x86_64":
        env["TARGET_ARCH"] = "amd64"
        link_flags.append("-machine:x64")
    elif env["arch"] == "x86_32":
        env["TARGET_ARCH"] = 'x86'
        link_flags.append("-machine:x86")
    env["is_msvc"] = True

    msvc.generate(env)
    env.Tool("mslib")
    env.Tool("mslink")

    env.Append(LIBS=['user32.lib', 'Ws2_32.lib', 'Crypt32.lib', 'Advapi32.lib'])
    env.Append(CPPDEFINES=["WIN32", "_WIN32", "_WINDOWS", "_CRT_SECURE_NO_WARNINGS"])

    cc_flags = cc_flags + ['-EHs', '-FS', '-GR', '-GS-', '-MT', '-nologo', '-Oy-', '-wd4996', '/fp:precise', '/WX-']
    if env['target'] == 'debug':
        cc_flags.append('-Od')
        link_flags.append('-debug:full')
    else:
        cc_flags.append('-O2')

elif env['platform'] == "linux":
    static_lib_name += '.a'
    shared_lib_name += '.dso'
    env.Append(ENV = os.environ)

    if env["arch"] == "x86_64":
        cc_flags.append('-m64')
    else:
        cc_flags.append('-m32')

    env.Append(CPPDEFINES=["_CRT_SECURE_NO_DEPRECATE"])
    cc_flags = cc_flags + ['-fpic', '-fPIC', '-frtti', '-fvisibility=hidden', '-std=c++11', '-Wno-invalid-offsetof', '-Wno-overflow', '-x', 'c++']

    if env['target'] == 'debug':
        cc_flags.append('-g')
    else:
        cc_flags.append('-O2')

elif env['platform'] == "macos":
    static_lib_name += '.a'
    shared_lib_name += '.dylib'
    env.Append(ENV = os.environ)

    if env["arch"] == "x86_64":
        cc_flags.append('-m64')
    else:
        cc_flags.append('-m32')

    env.Append(CPPDEFINES=["_CRT_SECURE_NO_DEPRECATE"])
    cc_flags = cc_flags + ['-frtti', '-fvisibility=hidden', '-std=c++11', '-Wno-invalid-offsetof', '-Wno-overflow', '-x', 'c++']
    if env['target'] == 'debug':
        cc_flags.append('-g')
    else:
        cc_flags.append('-O2')

env.Append(LINKFLAGS = link_flags)
env.Append(CCFLAGS = cc_flags)

# build shared objs here
env.VariantDir('bin/obj', f'{hxgodotPath}src/', duplicate=0)

# run haxe compile

if env['haxe_target'] == 'cppia':
    hxCmd = f'haxe script.hxml {libTargetString}'
else:
    hxCmd = f'haxe build.hxml {libTargetString}'
    hxCmd = hxCmd + ' -D HXCPP_GC_GENERATIONAL -D HXCPP_CPP11 -D static_link -cpp bin/ -cp bindings'
    if env["arch"] == "x86_64":
        hxCmd = hxCmd + ' -D HXCPP_M64'
    if env["scriptable"] == True:
        hxCmd = hxCmd + ' -D scriptable'

hxlib = env.Command('bin/'+static_lib_name, [], hxCmd)
env.AlwaysBuild(hxlib)

# build our lib
env.Append(CPPPATH=[
        'bin/include'
    ])
env.Append(LIBPATH=['bin/'])
env.Append(LIBS=[static_lib_name])

env.Append(CPPPATH=[f'bin/obj/'])
sources = Glob(f'bin/obj/*.cpp')

library = env.SharedLibrary(target='bin/' + shared_lib_name , source=sources)

# make the shared lib depend on hxcpp builds
env.Depends(library, hxlib)

# 
Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))
