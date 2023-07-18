<template>
  <div class="item">
    <i>
      <slot name="icon"></slot>
    </i>
    <div class="details">
      <h3>
        <slot name="heading"></slot>
      </h3>
      <slot></slot>
    </div>
  </div>
</template>

<style scoped>
.item {
  margin-top: 0;
  padding: 0.4rem 0 1rem calc(var(--section-gap) / 2);
  max-width: 650px;
  margin-left: 7vw;
}

.details {
  flex: 1;
}

h3 {
  font-weight: 500;
  margin-bottom: 0.4rem;
  color: var(--color-heading);
  font-size: 120%;
}

i {
  place-items: center;
  place-content: center;
  display: flex;
  left: 0px;
  position: absolute;
  border: 1px solid var(--color-border);
  background: var(--color-background);
  border-radius: 8px;
  width: 50px;
  height: 50px;
}

.item:before {
  content: ' ';
  border-left: 1px solid var(--color-border);
  position: absolute;
  left: 26px;
  height: calc(100% - 25px);
}

.item:first-of-type:before {
  display: none;
}

.item:last-of-type:after {
  display: none;
}
</style>
