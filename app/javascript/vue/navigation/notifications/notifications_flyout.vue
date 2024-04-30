<template>
  <div class="sci--navigation--notificaitons-flyout">
    <div class="sci--navigation--notificaitons-flyout-title">
      {{ i18n.t('nav.notifications.title') }}
      <a class="ml-auto cursor-pointer text-sm font-normal" :href="this.preferencesUrl" :title="i18n.t('nav.settings')">
        {{ i18n.t('nav.settings') }}
      </a>
    </div>
    <hr>
    <NotificationList :notificationsUrl="notificationsUrl" />
  </div>
</template>

<script>
import NotificationList from './notification_list.vue';

export default {
  name: 'NotificationsFlyout',
  components: {
    NotificationList
  },
  props: {
    notificationsUrl: String,
    unseenNotificationsCount: Number,
    preferencesUrl: String
  },
  beforeUnmount() {
    document.body.style.overflow = 'auto';
  },
  methods: {
    preventPropagation(e) {
      e.stopPropagation();
      e.preventDefault();
    }
  }
};
</script>
