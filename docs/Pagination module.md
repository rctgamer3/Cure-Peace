# > Pagination Module:

Pagination.js can be used as pagination builder and included inside `modules/discord`. Full documentation can be looked
up on https://www.npmjs.com/package/@acegoal07/discordjs-pagination & usage example can be looked on `anilist.js`
command.

Basic example:

```JS
const { Pagination } = require("../modules/discord/Pagination");

const pages = [];

new Pagination().setPortal(interaction)
    .setPageList(pages)
    .setButtonList(PaginationButton)
    .setTimeout(PaginationConfig.timeout)
    .paginate();
```