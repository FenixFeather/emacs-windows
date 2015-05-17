;;.emacs
;;Thomas Liu

(package-initialize)

(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/.emacs.d/lisp/ess-13.09-1/lisp")
(load "ess-site")

;;Windows specific
(add-hook 'LaTeX-mode-hook 'turn-on-reftex) 
(setq reftex-plug-into-AUCTeX t)
(setq-default ispell-program-name "aspell")

;;;Windows backup
(setq version-control t ;; Use version numbers for backups.
      kept-new-versions 10 ;; Number of newest versions to keep.
      kept-old-versions 0 ;; Number of oldest versions to keep.
      delete-old-versions t ;; Don't ask to delete excess backup versions.
      backup-by-copying t) ;; Copy all files, don't rename them.
  ;; Default and per-save backups go here:
(setq backup-directory-alist '(("" . "~/.emacs.d/backup/per-save")))

(defun force-backup-of-buffer ()
  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . "~/.emacs.d/backup/per-session")))
	  (kept-new-versions 3))
      (backup-buffer)))
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  (let ((buffer-backed-up nil))
    (backup-buffer)))

(add-hook 'before-save-hook  'force-backup-of-buffer)

;;Python
;;;Python mode
(add-to-list 'load-path "~/.emacs.d/python-mode")
(setq py-install-directory "~/.emacs.d/python-mode")
(require 'python-mode)

;;Package
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)

;;Loading
(load-library "valgrind")
(require 'mediawiki)

;;; yasnippet
;;; should be loaded before auto complete so that they can work together
(require 'yasnippet)
(yas-global-mode 1)

;;; auto complete mod
;;; should be loaded after yasnippet so that they can work together
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

;;;;More autocomplete
(require 'auto-complete-auctex)
(add-to-list 'ac-sources 'ac-source-c-headers)

;;;Markdown mode
;;(require 'markdown-mode)
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;Color Scheme
;(load-library "color-theme")
;; (require 'color-theme)
;; (eval-after-load "color-theme"
;;   '(progn
;;      (color-theme-initialize)
;;      (color-theme-subtle-hacker)))
(load-theme 'zenburn t)

;;Options
(electric-pair-mode 1)
(show-paren-mode 1)
(require 'ido)
(ido-mode t)

;;Templates
(require 'template)
(template-initialize)

(eval-after-load 'autoinsert
  '(define-auto-insert
     '("\\.\\(CC?\\|cc\\|cxx\\|cpp\\|c++\\)\\'" . "C++ skeleton")
     '("Short description: "
       "/*" \n
       (file-name-nondirectory (buffer-file-name))
       " -- " str \n
       " */" > \n \n
       "#include <iostream>" \n \n
       "using namespace std;" \n \n
       "main()" \n
       "{" \n
       > _ \n
       "}" > \n)))

(setq c-default-style "k&r"
          c-basic-offset 4)

(defun my-c++-mode-hook ()
  (c-set-style "k&r")        ; use my-style defined above
  (auto-fill-mode)         
  (c-toggle-auto-hungry-state 1)
  (electric-pair-mode 1))

(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;;C++ Stuff
  ; Create Header Guards with f12
(global-set-key [f12] 
  		'(lambda () 
  		   (interactive)
  		   (if (buffer-file-name)
  		       (let*
  			   ((fName (upcase (file-name-nondirectory (file-name-sans-extension buffer-file-name))))
  			    (ifDef (concat "#ifndef " fName "_H" "\n#define " fName "_H" "\n"))
  			    (begin (point-marker))
  			    )
  			 (progn
  					; If less then 5 characters are in the buffer, insert the class definition
  			   (if (< (- (point-max) (point-min)) 5 )
  			       (progn
  				 (insert "\nclass " (capitalize fName) "{\npublic:\n\nprivate:\n\n};\n")
  				 (goto-char (point-min))
  				 (next-line-nomark 3)
  				 (setq begin (point-marker))
  				 )
  			     )
  			   
  					;Insert the Header Guard
  			   (goto-char (point-min))
  			   (insert ifDef)
  			   (goto-char (point-max))
  			   (insert "\n#endif" " //" fName "_H")
  			   (goto-char begin))
  			 )
  		     ;else
  		     (message (concat "Buffer " (buffer-name) " must have a filename"))
  		     )
  		   )
  		)

(defun mp-add-cpp-keys()
  (local-set-key (kbd "C-.") 'insert-arrow)
  (local-set-key (kbd "C-c C-k" ) 'uncomment-region))

;;LaTeX Stuff
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)
(setq TeX-PDF-mode t)
(add-hook 'doc-view-mode-hook 'auto-revert-mode)

;;Useful functions
(defun insert-arrow ()
  "Insert -> at cursor point."
  (interactive)
  (insert "->"))

(defun insert-for-loop (var end)
  "Inserts a generic for loop."
  (interactive "sEnter iterator variable name: \nsEnter end variable name: ")
  (insert (format "for (int %s = 0;%s < %s;%s++){}" var var end var))
  (backward-char 1)
  )

;;Keybindings
;;(global-set-key (kbd "C-.") 'insert-arrow)

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
    (global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
    (global-set-key (kbd "S-C-<down>") 'shrink-window)
    (global-set-key (kbd "S-C-<up>") 'enlarge-window)

(global-set-key (kbd "<f1>") 'shell)
(global-set-key (kbd "<f5>") 'compile)
(global-set-key (kbd "C-c a") 'org-agenda)

;;Hooks
(add-hook 'c++-mode-hook 'mp-add-cpp-keys)
(add-hook 'org-mode-hook 'my-org-init)

;;Orgmode
(defun my-org-init ()
  (require 'typopunct)
  (typopunct-change-language 'english)
  (typopunct-mode 1)
  (visual-line-mode 1))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(doc-view-continuous t)
 '(doc-view-dvipdf-program "dvipdfm")
 (if (eq system-type 'windows-nt) '(doc-view-ghostscript-program "gswin64c"))
 '(inferior-julia-program-name "julia")
 '(longlines-wrap-follows-window-size t)
 '(mediawiki-site-alist (quote (("Wikipedia" "http://en.wikipedia.org/w/" "FenixFeather" "" "Main Page"))))
 '(org-indent-mode-turns-off-org-adapt-indentation nil)
 '(org-journal-dir (if (eq system-type 'windows-nt) "C:/Users/Thomas/Documents/journal/" "~/Documents/journal"))
 '(org-startup-indented t)
 '(org-startup-truncated nil)
 (if (eq system-type 'windows-nt) '(preview-gs-command "GSWIN64C.EXE"))
 '(reftex-cite-prompt-optional-args (quote maybe))
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Ubuntu Mono" :foundry "outline" :slant normal :weight normal :height 120 :width normal)))))
(put 'downcase-region 'disabled nil)
