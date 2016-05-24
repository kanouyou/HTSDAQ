from distutils.core      import setup
from distutils.extension import Extension
from Cython.Distutils    import build_ext
from Cython.Build        import cythonize

src = ["IMultiMeter.pyx", "IPowerSupply.pyx", "ISlowControlRun.pyx"]

ext0 = Extension( "IMultiMeter", [src[0]])
ext1 = Extension("IPowerSupply", [src[1]])
ext2 = Extension( "slowcontrol", [src[2]])

setup( name = "slowcontrol", \
       version = "0.5",  \
       author = "Y.Yang", \
       cmdclass = {"build_ext":build_ext}, \
       ext_modules = [ext0, ext1, ext2], \
       requires = ["matplotlib", "numpy", "visa"] \
     )
