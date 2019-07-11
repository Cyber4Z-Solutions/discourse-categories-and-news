import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  @computed
  newsTopics() {
    console.log("newsCategory", this, this.categories);
    console.log("topics", this.topics);
    return this.categories
  }
});
