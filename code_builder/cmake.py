import os.path, subprocess

from os.path import join, exists, isfile
from os import listdir, mkdir
from shutil import rmtree
from glob import iglob

def isCmakeProject(repo_dir):
    return isfile( join(repo_dir, 'CMakeLists.txt') )

class CMakeProject:

    def __init__(self, repo_dir):
        self.repository_path = repo_dir

    def build(self, c_compiler, cxx_compiler, force_update = False):
        self.build_dir = self.repository_path + "_build"
        # script is outside package directory
        if not exists(self.build_dir):
            mkdir(self.build_dir)
        elif len(listdir(self.build_dir)) == 0 or force_update:
            c_compiler_opt = "-DCMAKE_C_COMPILER=" + c_compiler
            cpp_compiler_opt = "-DCMAKE_CXX_COMPILER=" + cxx_compiler
            subprocess.run(["cmake", self.repository_path, c_compiler_opt, cpp_compiler_opt],
                    cwd=self.build_dir
                    )
        ret = subprocess.run(["cmake", "--build", "."], cwd=self.build_dir)

    def generate_bitcodes(self, target_dir):
        if not exists(target_dir):
            mkdir(target_dir)
        for file in iglob('{0}/**/*.ll'.format(self.build_dir), recursive=True):
            filename = os.path.basename(file)
            os.rename(file, os.path.join(target_dir, filename) )

    def clean(self):
        build_dir = self.repository_path + "_build"
        rmtree(build_dir)
        os.mkdir(build_dir)
