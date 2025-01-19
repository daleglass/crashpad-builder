#!/bin/bash
set -e
curdir=`pwd`

[ ! -d "depot_tools" ] && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

export PATH=$curdir/depot_tools:$PATH

[ ! -d "crashpad" ] && fetch crashpad

cd crashpad
gn gen out/Debug "--args=is_debug=true"
gn gen out/Release "--args=is_debug=false"

echo "is_debug=true" >> out/Debug/args.gn
echo "is_debug=false" >> out/Release/args.gn


ninja -C out/Debug
ninja -C out/Release

git_commit=`git rev-parse HEAD | cut -c -8`
git_date=`git show --no-patch --format=%cs HEAD`

packaged_dir="crashpad_${git_commit}"

cd ..
mkdir -p "$packaged_dir"
cd "$packaged_dir"


# This stuff here just imitates the contents that were found in the OSX package.
# There might be some better way of doing this.
mkdir -p include

for dir in client util/file util/misc util/numeric util/synchronization; do
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

[ -d "out" ] && rm -rf "out"

for build_type in Debug Release ; do

	mkdir -p out/${build_type}/lib
	cp -v ../crashpad/out/${build_type}/obj/util/libutil.a                                            out/${build_type}/lib/libcrashpad_util.a
	cp -v ../crashpad/out/${build_type}/obj/client/libclient.a                                        out/${build_type}/lib/libcrashpad_client.a
        cp -v ../crashpad/out/${build_type}/obj/client/libcommon.a                                        out/${build_type}/lib/libcrashpad_common.a
	cp -v ../crashpad/out/${build_type}/obj/handler/libhandler.a                                      out/${build_type}/lib/libcrashpad_handler.a

	cp -v ../crashpad/out/${build_type}/obj/third_party/mini_chromium/mini_chromium/base/libbase.a    out/${build_type}/lib/libbase.a
	cp -v ../crashpad/out/${build_type}/crashpad_handler                                              out/${build_type}/crashpad_handler
	cp -v ../crashpad/out/${build_type}/gen/build/chromeos_buildflags.h                               include/build/
done

	# Hack, fix later.
#ln -sf Debug out/Release

cd ..
tar -c --xz -vf crashpad_linux_${git_date}_${git_commit}.tar.xz "$packaged_dir"
md5sum          crashpad_linux_${git_date}_${git_commit}.tar.xz > MD5SUMS
sha256sum       crashpad_linux_${git_date}_${git_commit}.tar.xz > SHA256SUMS

echo "*** MD5 SUMS ***"
cat MD5SUMS
echo ""
echo "*** SHA256 SUMS ***"
cat SHA256SUMS
