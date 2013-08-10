(require 'tss)
(require 'el-expectations)
(require 'tenv)

(expectations
  (desc "process not exist before start")
  (expect nil
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (loop for buff in (buffer-list)
            if (string= (buffer-file-name buff) tfile)
            do (kill-buffer buff))
      (with-current-buffer (find-file-noselect tfile)
        (tss--exist-process))))
  (desc "process do start process by getting when not exist")
  (expect (mock (tss--start-process))
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (erase-buffer)
        (insert "var s1;\n")
        (save-buffer)
        (tss--get-process))))
  (desc "process start process")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--start-process))
      (loop for proc in (process-list)
            if (string= (process-name proc) "typescript-service-proctest")
            return (eq (process-status proc) 'run)
            finally return nil)))
  (desc "process exist after start")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--exist-process))))
  (desc "process not start process by getting when exist")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (stub tss--start-process => nil)
      (with-current-buffer (find-file-noselect tfile)
        (processp (tss--get-process)))))
  (desc "process delete process")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (stub kill-process => nil)
      (with-current-buffer (find-file-noselect tfile)
        (tss--delete-process))
      (loop for proc in (process-list)
            if (string= (process-name proc) "typescript-service-proctest")
            return (not (eq (process-status proc) 'run))
            finally return t)))
  (desc "process not exist after delete")
  (expect nil
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--exist-process))))
  (desc "process re-start process")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--start-process))
      (loop for proc in (process-list)
            if (string= (process-name proc) "typescript-service-proctest")
            return (eq (process-status proc) 'run)
            finally return nil)))
  (desc "process exist after re-start")
  (expect t
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--exist-process))))
  (desc "process kill process when start multiple")
  (expect (mock (kill-process))
    (let ((tfile (tenv-get-tmp-file "tss" "proctest" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (tss--start-process))))
  )
