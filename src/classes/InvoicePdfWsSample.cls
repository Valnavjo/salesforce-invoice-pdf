/**
 * @author      Valnavjo <valnavjo_at_gmail.com>
 * @version     1.0.0
 * @since       10/08/2014
 */
global with sharing class InvoicePdfWsSample {
	/**
	 * Default header height for invoice
	 */
	private static final String DEFAULT_INVOICE_HEADER_HEIGHT = '100';
	
	/**
	 * Default footer height for invoice
	 */
	private static final String DEFAULT_INVOICE_FOOTER_HEIGHT = '100';
	
	/**
	 * Webservice method that is called from a custom button to generate
	 * an invoice PDF file using quote templates feature.
	 * It generates the invoice based on:
	 * 		- The synced Quote, or
	 *		- The latest Quote
	 * If the Opportunity doesn't have any Quotes, this method doesn't do
	 * anything.
	 * 
	 * This method uses PageReference.getContent().
	 *
	 * @param oppsIdList {List<Id>} list of Opportunity Ids from where the method
	 *					 will generate the Invoice PDF.
	 * @return {String} with an error message, if any. Blank otherwise.
	 */
	webService static String generateInvoicePdf(List<Id> oppsIdList) {
		try {
			//From list to set
			final Set<Id> oppsId = new Set<Id>(oppsIdList);

			//Get template Id for Invoice and url to hack pdf generation
			final String invoiceTemplateId = Application_Properties__c.getAll().get('Invoice_Template_Id').value__c;
			String invoiceHeaderHeight = Application_Properties__c.getAll().get('Invoice_Header_Height').value__c;
			String invoiceFooterHeight = Application_Properties__c.getAll().get('Invoice_Footer_Height').value__c;
			final String quoteTemplateDataViewerUrl = Application_Properties__c.getAll().get('Quote_Template_Data_Viewer_URL').value__c;
			
			//Pre-validations
			//Invoice_Template_Id and Quote_Template_Data_Viewer_URL are mandatory 
			if (String.isBlank(invoiceTemplateId) || String.isBlank(quoteTemplateDataViewerUrl)) {
				String errorMsg = 'Invoice Template Id or Quote Template Data Viewer URL are blank, please review their values in Application Properties custom setting.';

				return errorMsg;
			}
			
			//Default values for invoice header/footer height
			if (String.isBlank(invoiceHeaderHeight)) invoiceHeaderHeight = DEFAULT_INVOICE_HEADER_HEIGHT;
			if (String.isBlank(invoiceFooterHeight)) invoiceFooterHeight = DEFAULT_INVOICE_FOOTER_HEIGHT; 

			//Iterate over Opps and generate Attachments list
			final List<Attachment> attList = new List<Attachment>();
			for (Opportunity opp : [select Id,
										   (select Id, Invoice_number__c, IsSyncing, CreatedDate
										   	from Quotes
										   	order by CreatedDate DESC)
									from Opportunity
									where Id IN :oppsId]) {
				//No Quotes, no party
				if (opp.Quotes.isEmpty()) continue;

				//Synced quote
				Quote theQuote = null;

				//Try to get the synced one
				for (Quote quoteAux : opp.Quotes) {
					if (quoteAux.IsSyncing) {
						theQuote = quoteAux;
						break;
					}
				}

				//No synced Quote, get the last one
				if (theQuote == null) theQuote = opp.Quotes.get(0);

				PageReference pageRef = new PageReference(
					quoteTemplateDataViewerUrl.replace('{!QuoteId}', theQuote.Id)
											  .replace('{!InvoiceHeaderHeight}', invoiceHeaderHeight)
											  .replace('{!InvoiceFooterHeight}', invoiceFooterHeight)
											  .replace('{!InvoiceTemplateId}', invoiceTemplateId)
				);

				attList.add(
					new Attachment(
						Name = 'Invoice #' + theQuote.Invoice_number__c + '.pdf',
						Body = pageRef.getContent(),
						ParentId = opp.Id
					)
				);
			}

			//Create Attachments
			if (!attList.isEmpty()) insert attList;
			
			return '';
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e.getMessage());

			final String errorMsg = 'An error has occured while generating the invoice. Details:\n\n' +
									 e.getMessage() + '\n\n' +
									 e.getStackTraceString();
			
			return errorMsg;
		}
	}
}