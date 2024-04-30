<template>
  <div>
    <div class="widget-header flex justify-between">
      <div class="widget-title">{{ i18n.t('nav.notifications.title') }}</div>
      <div class="btn btn-secondary btn-xs mr-2" @click="openSettings">Settings</div>
    </div>
    <div class="sci--navigation--notificaitons-flyout !w-full !h-[240px]">
      <NotificationList :key="filteredUrl" :notificationsUrl="filteredUrl" class="!p-3" />
    </div>
  </div>

  <div ref="modal" @keydown.esc="closeSettings" class="modal" role="dialog" aria-hidden="true" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <i class="sn-icon sn-icon-close"></i>
          </button>
          <h2 class="modal-title">{{ i18n.t('assets.delete_file_modal.title') }}</h2>
        </div>
        <div class="modal-body">
          <table>
            <template v-for="(_subGroups, group) in notificationGroups" :key="group">
              <div class="contents">
                <tr>
                  <td colspan=3 class="pt-6"><h3>{{ i18n.t(`notifications.groups.${group}`) }}</h3></td>
                </tr>
              </div>
              <template v-for="(_notifications, subGroup, i) in notificationGroups[group]" :key="subGroup">
                <tr
                    class="text-base border-transparent border-b-sn-super-light-grey border-solid"
                    :class="{'border-t-sn-super-light-grey': i == 0}"
                >
                  <td class="p-2.5 pr-10">{{ i18n.t(`notifications.sub_groups.${subGroup}`) }}</td>
                  <td class="p-2.5">
                    <div class="sci-toggle-checkbox-container">
                      <input type="checkbox"
                             class="sci-toggle-checkbox"
                             @change="setNotificationSettings(subGroup, $event.target.checked)"
                             :checked="this.notificationTypes.indexOf(subGroup) !== -1" />
                      <label class="sci-toggle-checkbox-label"></label>
                    </div>
                  </td>
                </tr>
              </template>
            </template>
          </table>
        </div>
        <div class="modal-footer">
          <button type='button' class='btn btn-secondary' @click="closeSettings">
            {{ i18n.t('general.close') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import NotificationList from './notification_list.vue';
import axios from '../../../packs/custom_axios.js';

export default {
  name: 'NotificationWidget',
  components: {
    NotificationList
  },
  props: {
    notificationsUrl: String,
    filterGroupsUrl: String,
    updateSettingsUrl: String,
    userSettingsUrl: String,
    notificationGroups: Object
  },
  data() {
    return {
      notificationTypes: []
    }
  },
  async created() {
    await axios.get(this.userSettingsUrl + '?key=widget_notification_subgroups').then((response) => {
      if (response.data.data) this.notificationTypes = response.data.data;
    });
  },
  computed: {
    filteredUrl() {
      return `${this.notificationsUrl}?${new URLSearchParams({ subgroups: this.notificationTypes }).toString()}`
    }
  },
  methods: {
    setNotificationSettings(type, enabled) {
      if (enabled && this.notificationTypes.indexOf(type) === -1) {
        this.notificationTypes = [...this.notificationTypes, type]
      } else {
        this.notificationTypes = this.notificationTypes.filter((t) => t != type)
      }

      axios.put(this.userSettingsUrl, {
        settings: [{ key: 'widget_notification_subgroups', data: this.notificationTypes }]
      });
    },
    openSettings() {
      $(this.$refs.modal).modal('show')
    },
    closeSettings() {
      $(this.$refs.modal).modal('hide')
    }
  }
};
</script>

