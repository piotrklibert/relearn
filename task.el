(progn
  (require 'ht)

  (defconst header-re (rx bol "[" (* any) "]"))
  (defun readlines (fname) (s-lines (f-read fname)))

  (defconst toml-chunks (->> (readlines "script.toml")
                          (--reject (string= "" it))
                          (--map (s-downcase (car (s-split " ?= ?" it))))
                          (-partition-by #f(s-matches? header-re %))))
  (defconst deps (elt toml-chunks 3))
  (defconst dev-deps (elt toml-chunks 5))

  (defsubst comment? (line) (s-starts-with? "#" line))
  (defsubst package? (line) (not (comment? line)))

  (cl-defun parse-comments (lines)
    (cl-loop with cmt for cur in lines
             if (comment? cur) do (setq cmt cur)
             else collect (prog1 (list cur cmt) (setq cmt nil))))
  (ppp-list (parse-comments dev-deps))
  ;; (defconst hash (ht))
  ;; (->> (readlines "script.txt")
  ;;   (--map (s-split (rx (or "==" (and white "@" white))) it))
  ;;   (--map (ht-set! hash (s-trim (s-downcase (first it))) (second it))))

  ;; (cl-flet ((out (s) (with-current-buffer "text1.txt" (insert s))))
  ;;   (with-current-buffer "text1.txt" (kill-region (point-min) (point-max))) ; not needed, convenience
  ;;   (cl-loop for dep in (append deps dev-deps)
  ;;            for ver = (ht-get hash dep)
  ;;            if ver do (out (format "%s==%s\n" dep ver))))
  )
