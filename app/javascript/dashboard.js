
import Vue from 'vue';
import modal from './components/modal';
import SiteStatusDropdown from './components/dashboard/SiteStatusDropdown';
import SiteIcon from './components/dashboard/SiteIcon.vue';

if (document.getElementById("claimed-worksites")) {
  var workerDashboardVue = new Vue({
    el: '#claimed-worksites',
    propsData: {
      siteId: null
    },
    components: {
      modal,
      SiteStatusDropdown,
      SiteIcon
    },
    data: {
      showModal: false,
      smsNumbers: ''
    },
    methods: {
      fireModal: function (siteId) {
        this.siteId = siteId;
        this.showModal = true;
      },
      cancelSend: function () {
        this.smsNumbers = '';
        this.showModal = false;
      },

      sendMessage: function () {
        var that = this;
        this.$http.post('/api/messages/send_sms.json',
          JSON.stringify({type: 'site-info', siteId: this.siteId, numbers: this.smsNumbers}),
          {
            headers: {'content-type': 'application/json'}
          }).then(function (response) {
          that.smsNumbers = '';
          this.showModal = false;
        }, function (error) {
          that.hasError = true;
          Raven.captureException(error.toString());
        });
      }
    }
  });
}
