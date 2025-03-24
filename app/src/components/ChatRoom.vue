<template>
  <div>
    <h1>チャットルーム {{ this.roomId }} </h1>

    <ul>
      <li v-for="message in messages" :key="message.id">
        <strong>{{ message.sender_name }}:</strong> {{ message.content }}
      </li>
    </ul>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ['roomId'],
  data() {
    return {
      roomName: '',
      messages: [],
    };
  },
  created() {
    this.fetchMessages();
  },
  methods: {
    fetchMessages() {
      axios
        .get(`http://localhost:3000/rooms/${this.roomId}/messages`)
        .then(response => {
          this.messages = response.data;
        })
        .catch(error => {
          console.error(error);
        });
    },
  },
};
</script>