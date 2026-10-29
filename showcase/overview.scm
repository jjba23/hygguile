;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The closing argument: why the framework renders on the server.

(define-module (showcase overview)
  #:use-module (hygguile hygguile)
  #:export (ssr-section))

(define ssr-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-2))))
              ,(p
                "Hygguile renders complete HTML on the server. The browser receives a finished document — headings, links, labels and controls included — and a little JavaScript enhances it afterwards."
                #:weight '(font-light))
              ,(p
                "\"Old school\" server rendering is not nostalgia. For the kinds of software most of us ship — content, forms, dashboards, admin panels — rendering on the server keeps the fast path fast and the simple path simple."
                #:weight '(font-light)))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-x-6
                                          gap-y-1 items-start))))
              ,(dl (list (dt "First paint without the framework tax")
                         (dd
                          "The HTML is ready to paint. There is no framework bundle to download, parse and execute before the first pixel, so pages feel immediate even on slow connections and modest hardware.")
                         (dt "No hydration, no double work")
                         (dd
                          "Nothing is re-rendered on the client just to attach behaviour. The server has already produced the final tree, so there is no hydration step that can disagree with the markup.")
                         (dt "It works when JavaScript does not")
                         (dd
                          "Links navigate and forms submit. Disclosure, tabs, the modal and tooltips keep working with scripting disabled; the theme toggle, carousel arrows and live notifications simply step in when they can.")
                         (dt "Accessible and discoverable by default")
                         (dd
                          "Real headings, landmarks, labels and form controls are present in the first byte, so assistive technology and crawlers never wait on a client-side rendering race.")))
              ,(dl (list (dt "One source of truth")
                         (dd
                          "State lives in the database and in the URL, not in a second client-side store. There is no model to duplicate, no cache to invalidate, and no stale-UI bug class caused by the two drifting apart.")
                         (dt "Cacheable and cheap to serve")
                         (dd
                          "A page is a pure function of its request, which makes responses easy to cache, compress and proxy. Payloads stay small: mostly text, styled by one stylesheet the browser already holds.")
                         (dt "A smaller, calmer stack")
                         (dd
                          "No client router, no global store, no build step that has to agree with the server. The mental model is the one the web began with: request a URL, receive a document, follow a link."))))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
              ,(p
                "Single-page applications earn their complexity when you genuinely need offline support or a deeply interactive workspace. Even then it is a spectrum rather than a binary: ship mostly-static HTML and add interactivity only where it repays its cost. That is exactly how Hygguile is built — a document first, with small islands of behaviour."
                #:weight '(font-light))
              ,(pre
                ";; A page is a pure function of its data
(define (page request)
  `((h1 \"Posts\")
    (ul ,@(map render-post (posts-for request)))))

;; Render it once, on the server, and send text to the browser")))))
