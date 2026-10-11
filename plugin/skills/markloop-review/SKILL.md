---
name: markloop-review
description: "Work the Markloop review loop for HTML documents (specs, proposals, plans, reports). Use when the user wants to publish or share a document on Markloop for comments, check or summarise what reviewers said, address or apply review comments and publish the next version, reply to reviewers, compare two versions of a document, or send a clean copy to a client's project."
---

# Markloop review loop

The Markloop server sends its own instructions and tool descriptions. Follow
them for the mechanics (pull, upload, versions, publish/republish). This skill
adds only the habits that keep the loop tidy across rounds.

## 1. Before anything

- If no `markloop_*` tools are available, say the Markloop connector is not
  connected and point the user to https://markloop.io/docs/connect. Do not
  improvise another way to upload.
- Pick the project with `markloop_whoami` or `markloop_list_projects`. When
  more than one project fits the request, ask the user which one. Never guess
  between projects.

## 2. Remember which document a local file is

When you work with files on disk, keep a `.markloop.json` next to the file,
or one at the repository root, mapping each local path to its document:

```json
{
  "docs/order-sync-spec.html": {
    "projectId": "…",
    "fileId": "…",
    "viewUrl": "https://app.markloop.io/…"
  }
}
```

- Read it before publishing. If the path is listed, publish a new version of
  that `fileId`; do not create a new document.
- Write or update the entry after every create or new version.
- Without a filesystem, find the document by name with `markloop_list_files`.
- Never create a second document for something already published. Publish a
  new version instead.

## 3. Address review comments

1. Pull the document with its open comments.
2. Read each thread in full. The latest messages matter most: a reviewer may
   have changed their mind or answered your earlier question.
3. Decide per thread: **change** the document, **ask** a question, or
   **decline** with a reason.
4. Edit the file.
5. When the changes are substantial, or the user asked to review first, show
   a short summary of the diff and wait for a go-ahead.
6. Upload the new version. Mark as addressed only the threads you actually
   changed the document for.
7. In each thread you skipped, declined or need input on, post one short reply.
8. Report back:
   - the link (`viewUrl`) of the new version,
   - what changed,
   - which comments were addressed (by number),
   - which were answered or skipped, and why.

Refer to comments by their number when talking to the user ("comment 3").

## 4. Publish a document for the first time

- Confirm the target project with the user unless it is unambiguous.
- After the document is created, give the user its `viewUrl`.
- Tell the user that a public comment link (anyone can comment, no account)
  comes from the **Share** button in the web app. Agents cannot create share
  links.

## 5. Send a clean copy to a client

- First hand-off: `markloop_publish_document` into the client's project.
- Later updates: `markloop_republish_document` onto that copy. Tell the user
  it replaces what the client sees; earlier versions stay in the history.
- Comments never cross between copies. Address the client's comments on the
  copy itself, in the client's project.
- Record the copy in `.markloop.json` too (its own `projectId`, `fileId`,
  `viewUrl`) so the next refresh goes to the same copy.

## 6. Rules

- Never invent comment content. Quote reviewers exactly.
- Do not resolve threads you did not address, unless the user says so.
- Markloop has no delete through the connector. If asked to delete a
  document, version or comment, say so and point the user to the web app at
  https://app.markloop.io.
