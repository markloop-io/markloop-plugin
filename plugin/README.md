# Markloop

Share the HTML documents and artifacts your AI writes, collect comments,
and publish the next version.

[Markloop](https://markloop.io) turns the HTML documents and artifacts your AI writes
(specs, proposals, plans, reports) into one link your team or clients can
comment on. Reviewers click an element or select text and leave a comment,
with no account needed on a public link.

This plugin connects your AI tool to Markloop and adds the `markloop-review`
skill, so your agent works the review loop for you:

- publishes a document into a Markloop project and gives you the link,
- reads the open comments as full threads, each with the exact sentence it is
  about,
- applies the changes and publishes the next version at the same link,
  marking which comments it addressed,
- replies in a thread when it needs an answer, and compares any two versions,
- sends a clean copy to a client's project, without your internal comments.

## How to use it

Install the plugin, then ask in plain words. The first Markloop request opens
a browser window where you sign in to Markloop and choose what the agent may
reach.

```text
Publish docs/order-sync-spec.html to Markloop so the team can comment.
What did reviewers say about the order sync spec? Group the comments by section.
Address the open comments on the order sync spec and publish the next version.
Reply to comment 2: we'll look contractors up by code in Atlas.
Send a clean copy of the go-live checklist to the client's project.
```

You need a Markloop account. Setup for each AI tool:
https://markloop.io/docs/connect

## What it sends, and where

- **Server.** The plugin connects to one remote MCP server,
  `https://app.markloop.io/api/mcp`, run by Markloop. It contains no scripts,
  hooks or local programs.
- **Sign-in.** You sign in with OAuth in your browser. The plugin stores no
  password, token or API key; your AI tool keeps the sign-in.
- **Access.** At sign-in you choose the workspaces (and, if you want, only
  selected projects) the agent may reach. You can disconnect at any time at
  https://app.markloop.io/connect.
- **Reads.** Documents, versions and comment threads in the workspaces and
  projects you granted.
- **Uploads.** Only the documents you ask the agent to publish, and the new
  versions it makes of them.
- **Writes.** New documents, new versions, comments, replies and copies of a
  document in another project. Updating a copy replaces what its readers see;
  earlier versions are kept.
- **Never deletes.** Nothing can be deleted through the plugin.
- **No AI on the server.** Markloop runs no AI model on its servers. All
  editing happens in your AI tool. Your content is not used to train AI
  models.

Details: [data and security](https://markloop.io/docs/data-security),
[privacy policy](https://markloop.io/privacy-policy),
[terms of service](https://markloop.io/terms-of-service).

## Help

- Documentation: https://markloop.io/docs
- Tool reference: https://markloop.io/docs/mcp-tools
- Troubleshooting: https://markloop.io/docs/troubleshooting
- Support: hi@markloop.io

License: MIT (see `LICENSE`).
