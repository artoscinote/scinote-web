<template>
  <div class="p-4 w-full rounded bg-sn-light-grey min-h-[68px]" data-e2e="e2e-CO-actionToolbar">
    <div class="flex gap-4 items-center h-full">
      <div v-if="loading && !actions.length" class="sn-action-toolbar__action">
        <a class="rounded flex items-center py-1.5 px-2.5 bg-transparent text-transparent no-underline"></a>
      </div>
      <div v-if="!loading && actions.length === 0" class="text-sn-grey-grey">
        {{ i18n.t('action_toolbar.no_actions') }}
      </div>
      <div v-for="action in actions" :key="action.name" class="sn-action-toolbar__action shrink-0" :class="{ 'disable-click': disabledActions[action.name] }">
        <template v-if="action.type === 'group'">
          <MenuDropdown
            v-if="action.actions.length > 1"
            :listItems="groupItems(action)"
            :btnClasses="buttonClasses"
            :btnText="action.group_label"
            :btnIcon="groupIcon(action)"
            :caret="true"
            :smallScreenCollapse="true"
            :title="action.group_label"
            :dataE2e="`e2e-DD-actionToolbar-${e2eName(action)}`"
            @groupAction="doAction"
          ></MenuDropdown>
          <a v-else-if="action.actions.length === 1"
            :class="`${buttonClasses} ${action.actions[0].button_class || ''}`"
            :href="(['link', 'remote-modal']).includes(action.actions[0].type) ? action.actions[0].path : '#'"
            :data-target="action.actions[0].target"
            :data-toggle="action.actions[0].type === 'modal' && 'modal'"
            :id="action.actions[0].button_id"
            :title="action.group_label"
            :data-e2e="`e2e-BT-actionToolbar-${e2eName(action)}`"
            @click="doAction(action.actions[0], $event)">
            <i :class="groupIcon(action)"></i>
            <span class="tw-hidden xl:inline-block">{{ action.group_label }}</span>
          </a>
        </template>
        <a v-else :class="`${buttonClasses} ${action.button_class || ''}`"
          :href="(['link', 'remote-modal']).includes(action.type) ? action.path : '#'"
          :data-target="action.target"
          :data-toggle="action.type === 'modal' && 'modal'"
          :id="action.button_id"
          :title="action.label"
          :data-e2e="`e2e-BT-actionToolbar-${action.name}`"
          @click="doAction(action, $event)">
          <i :class="action.icon"></i>
          <span class="tw-hidden xl:inline-block">{{ action.label }}</span>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '../../../packs/custom_axios.js';
import MenuDropdown from '../menu_dropdown.vue';

export default {
  name: 'ActionToolbar',
  components: {
    MenuDropdown
  },
  props: {
    actionsUrl: { type: String, required: true },
    actionsMethod: { type: String, default: 'post' },
    params: { type: Object },
  },
  data() {
    return {
      actions: [],
      multiple: false,
      reloadCallback: null,
      loaded: false,
      loading: true,
      disabledActions: {}
    };
  },
  computed: {
    buttonClasses() {
      return 'rounded flex gap-2 items-center py-1.5 px-1.5 xl:px-2.5 border-0 outline-none cursor-pointer '
        + 'bg-sn-white text-sn-blue hover:text-sn-white hover:bg-sn-blue hover:no-underline focus:no-underline';
    }
  },
  watch: {
    params() {
      this.loadActions();
    },
  },
  created() {
    this.loadActions();
  },
  methods: {
    loadActions() {
      this.loading = true;
      this.loaded = false;

      axios.request({
        method: this.actionsMethod,
        url: this.actionsUrl,
        params: this.actionsMethod === 'get' && this.params,
        data: this.actionsMethod !== 'get' && this.params
      }).then((response) => {
        this.actions = response.data.actions;
        this.loading = false;
        this.loaded = true;
      });
    },
    groupIcon(action) {
      return action.icon || action.actions[0]?.icon;
    },
    // keeps the e2e ids of grouped actions in line with the legacy toolbar
    e2eName(action) {
      return action.name.replace(/_group$/, '');
    },
    // maps group sub actions to the MenuDropdown list item format
    groupItems(action) {
      return action.actions.map((subAction) => ({
        text: subAction.label,
        emit: 'groupAction',
        params: subAction,
        url: (['link', 'remote-modal']).includes(subAction.type) ? subAction.path : null,
        modalTarget: subAction.type === 'modal' ? subAction.target : null,
        e2e_class: subAction.button_class,
        data_e2e: `e2e-BT-actionToolbar-${subAction.name}`
      }));
    },
    doAction(action, event) {
      this.disabledActions[action.name] = true;

      setTimeout(() => {
        delete this.disabledActions[action.name];
      }, 1000); // enable action after one second, to prevent multi-clicks

      switch (action.type) {
        case 'emit':
          // dropdown items are emitted without an event, MenuDropdown already prevents the default
          event?.preventDefault();
          this.$emit('toolbar:action', action);
          break;
        case 'modal':
          // do nothihg, boostrap modal handled by data-toggle="modal" and data-target
          break;
        case 'link':
          // do nothing, already handled by href
          break;
        default:
          break;
      }
    },
  },
};
</script>
