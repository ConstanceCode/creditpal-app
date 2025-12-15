import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState, useEffect } from "react";
function TopicInput() {
  return __jacJsx("div", {}, [__jacJsx("label", {"htmlFor": "topic"}, ["Enter topics you are interested in:"]), __jacJsx("input", {"type": "text", "id": "topic", "name": "topic", "placeholder": "Type your topic here..."}, [])]);
}
function app() {
  let [topics, setTopics] = useState([]);
  return __jacJsx("div", {}, [__jacJsx(TopicInput, {}, [])]);
}
export { TopicInput, app };
