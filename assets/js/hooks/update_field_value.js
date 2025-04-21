const UpdateFieldValue = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      const value = e.target.value;
      const crop = e.target.id.replace("field-", "");
      const valueSpan = document.getElementById(`value-${crop}`);
      if (valueSpan) {
        valueSpan.textContent = value;
      }
    });
  },
};

export default UpdateFieldValue;
