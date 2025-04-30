const UpdateTotalFields = {
  mounted() {
    this.el.addEventListener("change", (e) => {
      // Calculate total fields
      const totalFields = Array.from(
        document.querySelectorAll('select[name^="fields["]')
      ).reduce((sum, select) => sum + parseInt(select.value), 0);

      const totalSpan = document.getElementById("total-fields");
      if (totalSpan) {
        totalSpan.textContent = totalFields;
        if (totalFields > 4) {
          totalSpan.classList.add("text-red-600");
          totalSpan.classList.remove("text-green-600");
        } else {
          totalSpan.classList.add("text-green-600");
          totalSpan.classList.remove("text-red-600");
        }
      }
    });
  },
};

export default UpdateTotalFields;
