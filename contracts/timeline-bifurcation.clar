;; Timeline Bifurcation Contract

(define-map timelines uint
  { description: (string-utf8 256),
    parent: (optional uint),
    active: bool })

(define-data-var next-timeline-id uint u0)

(define-public (create-timeline (description (string-utf8 256)) (parent (optional uint)))
  (let ((new-id (+ (var-get next-timeline-id) u1)))
    (var-set next-timeline-id new-id)
    (map-set timelines new-id
      { description: description,
        parent: parent,
        active: true })
    (ok new-id)))

(define-public (merge-timelines (timeline1 uint) (timeline2 uint) (new-description (string-utf8 256)))
  (let ((t1 (unwrap! (map-get? timelines timeline1) (err u404)))
        (t2 (unwrap! (map-get? timelines timeline2) (err u404))))
    (asserts! (and (get active t1) (get active t2)) (err u403))
    (map-set timelines timeline1 (merge t1 { active: false }))
    (map-set timelines timeline2 (merge t2 { active: false }))
    (create-timeline new-description (some timeline1))))

(define-read-only (get-timeline (id uint))
  (ok (map-get? timelines id)))

(define-read-only (is-active-timeline (id uint))
  (let ((timeline (unwrap! (map-get? timelines id) (err u404))))
    (ok (get active timeline))))

