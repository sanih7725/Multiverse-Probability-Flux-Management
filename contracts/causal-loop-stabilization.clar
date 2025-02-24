;; Causal Loop Stabilization Contract

(define-map causal-loops uint
  { description: (string-utf8 256),
    start-event: uint,
    end-event: uint,
    stability: uint })

(define-data-var next-loop-id uint u0)

(define-public (register-causal-loop (description (string-utf8 256)) (start-event uint) (end-event uint))
  (let ((new-id (+ (var-get next-loop-id) u1)))
    (var-set next-loop-id new-id)
    (map-set causal-loops new-id
      { description: description,
        start-event: start-event,
        end-event: end-event,
        stability: u50 })
    (ok new-id)))

(define-public (stabilize-loop (loop-id uint))
  (let ((loop (unwrap! (map-get? causal-loops loop-id) (err u404))))
    (asserts! (< (get stability loop) u100) (err u400))
    (ok (map-set causal-loops loop-id
      (merge loop { stability: (+ (get stability loop) u10) })))))

(define-public (destabilize-loop (loop-id uint))
  (let ((loop (unwrap! (map-get? causal-loops loop-id) (err u404))))
    (asserts! (> (get stability loop) u0) (err u400))
    (ok (map-set causal-loops loop-id
      (merge loop { stability: (- (get stability loop) u10) })))))

(define-read-only (get-causal-loop (id uint))
  (ok (map-get? causal-loops id)))

(define-read-only (is-loop-stable (id uint))
  (let ((loop (unwrap! (map-get? causal-loops id) (err u404))))
    (ok (>= (get stability loop) u70))))

