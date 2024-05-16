import { useState } from "react";
import "./Editor.scss";

export function Editor() {
  const [content, saveContent] = useState(
    "Using Python as backend, you can perform operations that are not allowed in Javascript, for example disk access. Click button below to save this content to hard drive."
  );

  return (
    <div className="editor-container">
      <textarea
        className="textarea"
        value={content}
        onChange={(e) => {
          saveContent(e.target.value);
        }}
      />
      <br />

      <button
        className="button"
        onClick={() => {
          // @ts-expect-error TS2339: Property 'pywebview' does not exist on type 'Window & typeof globalThis'.
          window.pywebview.api.save_content(content);
        }}
      >
        Save
      </button>
    </div>
  );
}
