export default Ember.Component.extend({
  didInsertElement() {
    this.$('.categories-news-carousel').slick({
      autoplay: true,
      dots: true
    });
  },
});
