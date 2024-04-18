// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create("ChatChannel", {
  connected() {
    console.log("Connected to the chat channel!");
  },

  disconnected() {
    console.log("Disconnected from the chat channel!");
  },

  received(data) {
    console.log("Receiving:", data);
  },

  speak(message) {
    this.perform('speak', { message: message });
  }
});

export default chatChannel;
