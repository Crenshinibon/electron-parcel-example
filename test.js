import test from "ava";
import electronParcelExample from ".";

test("exports a function", t => {
  t.is(typeof electronParcelExample, "function");
});
