import { withPluginApi } from "discourse/lib/plugin-api";

function initializeCategoriesAndNews(api) {
  api.modifyClass("route:discovery-categories", {
    findCategories() {
      let style =
        !this.site.mobileView && this.siteSettings.desktop_category_page_style;

      if(style == "categories_and_news") {
        return this._findCategoriesAndTopics("news");
      }

      return this._super();
    }
  });
}

export default {
  name: "apply-categories-and-news",

  initialize() {
    withPluginApi("0.8.8", initializeCategoriesAndNews);
  }
};
