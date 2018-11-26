(define-module (julia-hack)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages elf))

(define-public julia
  (package
    (name "julia")
    (version "1.0.2")
    (inputs `(("glibc" ,glibc)
	      ("patchelf" ,patchelf)
	      ("tar" ,tar)
	      ("coreutils" ,coreutils)
	      ("gzip" ,gzip)))
    (propagated-inputs `(("wget" ,wget)))
    (supported-systems '("x86_64-linux"))
    (source (origin
	      (method url-fetch)
	      (uri "https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.2-linux-x86_64.tar.gz")
	      (sha256
	       (base32
	        "0hpisary2n00vya6fxlfbzpkz2s82gi7lzgjsm3ari1wfm4kksg0"))))
    (build-system trivial-build-system)
    (arguments
     '(#:modules
       ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let*
	     ((out (assoc-ref %outputs "out"))
	      (source (assoc-ref %build-inputs "source"))
	      (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
	      (patchelf (string-append (assoc-ref %build-inputs "patchelf") "/bin/patchelf"))
	      (ld (string-append (assoc-ref %build-inputs "glibc") "/lib/ld-linux-x86-64.so.2"))
	      (ln (string-append (assoc-ref %build-inputs "coreutils") "/bin/ln"))
	      (cp (string-append (assoc-ref %build-inputs "coreutils") "/bin/cp"))
	      (mv (string-append (assoc-ref %build-inputs "coreutils") "/bin/mv"))
	      (rm (string-append (assoc-ref %build-inputs "coreutils") "/bin/rm"))	   	   
	      (PATH
	       (string-append
	        (assoc-ref %build-inputs "gzip") "/bin"
	        ":"
	        (assoc-ref %build-inputs "tar") "/bin")))
	   (mkdir-p out)
	   (mkdir-p (string-append out "/bin"))
	   (with-directory-excursion out
	     (setenv "PATH" PATH)
	     (system* tar "xf" source "--strip-components=1")
	     (system* patchelf
		      "--set-interpreter"
		      ld
		      (string-append out "/bin/julia"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia" ":" out "/lib")
		      (string-append out "/lib/julia/sys.so"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia")
		      (string-append out "/lib/julia/libLLVM.so"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia")
		      (string-append out "/lib/julia/libLLVM-6.so"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia")
		      (string-append out "/lib/julia/libLLVM-6.0.so"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia")
		      (string-append out "/lib/julia/libLLVM-6.0.0.so"))
	     (system* patchelf
		      "--set-rpath"
		      (string-append out "/lib/julia")
		      (string-append out "/lib/julia/libstdc++.so.6")))))))
    (synopsis "Julia")
    (description "better than matlab at least")
    (home-page "http://julialang.org")
    (license "oh well")))

