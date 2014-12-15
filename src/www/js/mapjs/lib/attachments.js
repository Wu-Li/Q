$.fn.attachmentEditorWidget = function (mapModel) {
    'use strict';
	return this.each(function () {
		var element = $(this);
		mapModel.addEventListener('attachmentOpened', function (nodeId, attachment) {
			mapModel.setAttachment(
				'attachmentEditorWidget',
				nodeId, {
					contentType: 'text/html',
					content: prompt('attachment', attachment && attachment.content)
				}
			);
		});
	});
};