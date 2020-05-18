#!/bin/bash
set -e
curdir=`pwd`

[ ! -d "depot_tools"] && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

export PATH=$curdir/depot_tools:$PATH

[ ! -d "crashpad" ] && fetch crashpad

cd crashpad
gn gen out/Default
ninja -C out/Default
git_commit=`git rev-parse HEAD | cut -c -8`
packaged_dir="crashpad_${git_commit}"

cd ..
mkdir -p "$packaged_dir"
cd "$packaged_dir"


# This stuff here just imitates the contents that were found in the OSX package.
# There might be some better way of doing this.
mkdir -p include

for dir in client util/file util/misc util/numeric ; do
	mkdir -p "include/$dir"
	cp -v ../crashpad/$dir/*.h include/$dir/
done

for dir in base build ; do
	mkdir -p "include/$dir/"
	for file in `find ../crashpad/third_party/mini_chromium/mini_chromium/$dir -name '*.h' -printf '%P\n'` ; do
		reldir=`dirname "$file"`
		mkdir -p "include/$dir/$reldir"
		cp -v "../crashpad/third_party/mini_chromium/mini_chromium/$dir/$file" "include/$dir/$reldir/"
	done
done


mkdir -p out/Debug/lib
cp -v ../crashpad/out/Default/obj/util/libutil.a                                            out/Debug/lib/libcrashpad_util.a
cp -v ../crashpad/out/Default/obj/client/libclient.a                                        out/Debug/lib/libcrashpad_client.a
cp -v ../crashpad/out/Default/obj/third_party/mini_chromium/mini_chromium/base/libbase.a    out/Debug/lib/libbase.a
cp -v ../crashpad/out/Default/crashpad_handler                                              out/Debug/crashpad_handler

# Hack, fix later.
ln -sf Debug out/Release

cd ..
tar -cjvf crashpad_linux_${git_commit}.tar.bz2 "$packaged_dir"
md5sum crashpad_linux_${git_commit}.tar.bz2 >> MD5SUMS
cat MD5SUMS
