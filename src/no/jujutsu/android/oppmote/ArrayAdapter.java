package no.jujutsu.android.oppmote;

import android.R;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckedTextView;

public class ArrayAdapter extends android.widget.ArrayAdapter<Object> {

	private final LayoutInflater inflater;
	private final int list_item_layout_id;

	public ArrayAdapter(Context context, int textViewResourceId,
			Object[] objects) {
		super(context, textViewResourceId, objects);
		System.out.println("Created ArrayAdapter");
		list_item_layout_id = textViewResourceId;
		inflater = (LayoutInflater) getContext().getSystemService(
				Context.LAYOUT_INFLATER_SERVICE);
	}

	public android.view.View getView(int position,
			android.view.View convertView, android.view.ViewGroup parent) {
		System.out.println("OrderAdapter.getView: pos: " + position);
		View row;
		if (null == convertView) {
			row = inflater.inflate(list_item_layout_id, null);
		} else {
			row = convertView;
		}

		String[] item = (String[]) getItem(position);
		System.out.println("Member : " + item[0]);
		System.out.println("Present: " + item[1] + " " + item[1].equals("true"));
		((CheckedTextView) row.findViewById(R.id.text1)).setText((CharSequence) item[0]);
		((CheckedTextView) row.findViewById(R.id.text1)).setChecked(item[1].equals("true"));
		((CheckedTextView) row.findViewById(R.id.text1)).setChecked(true);

		return row;
	}
}
