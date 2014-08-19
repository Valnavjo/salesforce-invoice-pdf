salesforce-invoice-pdf
======================
Quotes have a powerful built-in tool in Salesforce to generate PDF files based on templates. In this post I will explain how you can take advantage of this feature to generate Invoices. In most cases, the template used for a Quote is different from the one used for an Invoice. Salesforce only brings you the option to create Quote PDFs within the Quote object and it doesn't allow you to change the name of the file. Below I will explain how you can generate Invoice PDFs files based on Quote templates from any Object in Salesforce by just clicking a custom button.
<!--more-->
<h3>Requirements</h3>
<ul>
	<li>Quotes must be enabled in your Salesforce organization. Click <a href="https://help.salesforce.com/HTViewHelpDoc?id=quotes_enable.htm&language=en_US" target="_blank">here</a> for more information.</li>
</ul>

<h3>Features</h3>
<ul>
	<li>Hack Quote Templates to dynamically generate PDFs.</li>
	<li>Easily generate Invoice PDF files based on the synced or latest created Quote.</li>
	<li>Save PDF as an Attachment, allowing you to change the name of the file.</li>
	<li>No need to use third party libraries.</li>
</ul>

<h3>How it works</h3>
I'm using PageReference.getContent() method to retrieve the PDF blob. Ideally this logic would happen within a trigger context or in a background process. However, getContent() method cannot be used in Triggers, Scheduled Apex or Batch jobs. This only gives us the option of using an Apex Controller class.

See the full reference <a href="http://www.valnavjo.com/blog/?p=469" target="_blank">here</a>.

Be Apex my friend!
