/*
 * Copyright (C) 2017 Katarina Sheremet
 * This file is part of Delern.
 *
 * Delern is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Delern is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with  Delern.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.dasfoo.delern.util;

import android.animation.Animator;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.view.View;
import android.view.ViewAnimationUtils;

/**
 * Class for animation logic.
 */
public final class Animation {

    /**
     * Hide utility class default constructor.
     */
    private Animation() {
    }

    /**
     * Creates appearance animation for a view.
     *
     * @param view view
     * @return animation for view
     */
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static Animator appearanceAnimation(final View view) {
        // get the center for the clipping circle
        int cx = view.getWidth() / 2;
        int cy = view.getHeight() / 2;
        // get the final radius for the clipping circle
        float finalRadius = (float) Math.hypot(cx, cy);
        return ViewAnimationUtils.createCircularReveal(view, cx, cy, 0, finalRadius);
    }
}