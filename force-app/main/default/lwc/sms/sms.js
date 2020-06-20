import { LightningElement, wire,track, api } from 'lwc';
import sendSMS from '@salesforce/apex/SmsProviders.sendSMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class App extends LightningElement {

    @track mobile;
    @track messageSMS;

    handleMobileChange(evt){
        this.mobile = evt.target.value;
    }

    handlemessageSMSChange(evt){
        this.messageSMS = evt.target.value;
    }

    sendSMS(e){
        console.log('============================>' + this.mobile);
        console.log('============================>' + this.messageSMS);

        if (this.mobile !== '' && this.messageSMS !== '') {
            sendSMS({
                mobile: this.mobile,
                message: this.messageSMS
                })
                .then((result) => {
                     
					this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'SMS Sent successfully!',
                        variant: 'success'
                    })
                );
				
                })
                .catch((error) => {
                    // display server exception in toast msg 
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'Request error',
                    });
                    this.dispatchEvent(event);
                    // reset accounts var with null   
                    this.accounts = null;
                });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Mobile or Message is empty'
            });
            this.dispatchEvent(event);
        } 
    }
}