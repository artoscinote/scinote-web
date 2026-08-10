<template>
  <div ref="modal" @keydown.esc="close" class="modal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document" data-e2e="e2e-MD-invInventoryExportItemsAT">
      <form @submit.prevent="submit" class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close" data-e2e="e2e-BT-exportMD-close">
            <i class="sn-icon sn-icon-close"></i>
          </button>
          <h4 class="modal-title">{{ i18n.t('zip_export.repositories_modal_label') }}</h4>
        </div>
        <div class="modal-body">
          <div class="mb-6" v-html="i18n.t('zip_export.repository_header_html', { repository: escapeHtml(repositoryName) })"></div>
          <div class="mb-6" v-html="i18n.t('zip_export.repository_footer_html')"></div>
          <div class="sci-radio-container">
            <input type="radio" class="sci-radio" name="file_type" value="xlsx" v-model="selectedFileType">
            <span class="sci-radio-label"></span>
          </div>
          <label class="mr-6 ml-3 mb-0 font-normal">.xlsx</label>
          <div class="sci-radio-container">
            <input type="radio" class="sci-radio" name="file_type" value="csv" v-model="selectedFileType">
            <span class="sci-radio-label"></span>
          </div>
          <label class="mr-6 ml-3 mb-0 font-normal">.csv</label>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal" data-e2e="e2e-BT-exportMD-cancel">
            {{ i18n.t('general.cancel') }}
          </button>
          <button type="submit" class="btn btn-primary" :disabled="submitting" data-e2e="e2e-BT-exportMD-export">
            {{ i18n.t('my_modules.repository.export') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
/* global HelperModule */

import axios from '../../../packs/custom_axios.js';
import escapeHtml from '../../shared/escape_html.js';
import modalMixin from '../../shared/modal_mixin';

export default {
  name: 'ExportRepositoryRowsModal',
  props: {
    repositoryName: String,
    rows: Array,
    headerIds: Array,
    exportAction: Object
  },
  mixins: [modalMixin],
  data() {
    return {
      selectedFileType: this.exportAction.export_file_type || 'xlsx',
      submitting: false,
      escapeHtml
    };
  },
  methods: {
    submit() {
      if (this.submitting) return;

      this.submitting = true;

      axios.post(this.exportAction.path, {
        row_ids: this.rows.map((row) => row.id),
        header_ids: this.headerIds,
        file_type: this.selectedFileType
      }).then((response) => {
        this.submitting = false;
        HelperModule.flashAlertMsg(response.data.message, 'success');
        this.close();
      }).catch((error) => {
        this.submitting = false;
        HelperModule.flashAlertMsg(error.response?.data?.message || this.i18n.t('general.error'), 'danger');
      });
    }
  }
};
</script>
