export default Ember.Component.extend({
  didInsertElement() {
    this.$('.categories-news-carousel').slick({
      autoplay: true,
      autoplaySpeed: 10000,
      dots: true
    });
  },
});
